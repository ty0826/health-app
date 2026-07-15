package com.health.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.health.dto.HealthDataRequest;
import com.health.entity.HealthData;
import com.health.mapper.HealthDataMapper;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class HealthDataService {

    @Autowired
    private HealthDataMapper healthDataMapper;

    public void addRecord(Long userId, HealthDataRequest request) {
        HealthData data = new HealthData();
        BeanUtils.copyProperties(request, data);
        data.setUserId(userId);

        if (request.getRecordDate() != null) {
            data.setRecordDate(LocalDate.parse(request.getRecordDate()));
        } else {
            data.setRecordDate(LocalDate.now());
        }

        // 检查当天是否已有记录，有则更新
        HealthData existing = healthDataMapper.selectByUserAndDate(userId, data.getRecordDate());
        if (existing != null) {
            data.setId(existing.getId());
            healthDataMapper.updateById(data);
        } else {
            healthDataMapper.insert(data);
        }
    }

    public List<HealthData> getRecordList(Long userId, int page, int size) {
        Page<HealthData> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<HealthData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HealthData::getUserId, userId)
                .orderByDesc(HealthData::getRecordDate);
        return healthDataMapper.selectPage(pageParam, wrapper).getRecords();
    }

    public HealthData getTodayRecord(Long userId) {
        return healthDataMapper.selectByUserAndDate(userId, LocalDate.now());
    }

    public Map<String, Object> getStats(Long userId, int days) {
        LocalDate startDate = LocalDate.now().minusDays(days - 1);
        List<HealthData> records = healthDataMapper.selectByDateRange(userId, startDate);

        Map<String, Object> stats = new HashMap<>();

        // 计算平均值
        if (!records.isEmpty()) {
            stats.put("avgSteps", (int) records.stream().mapToInt(r -> r.getSteps() != null ? r.getSteps() : 0).average().orElse(0));
            stats.put("avgHeartRate", (int) records.stream().mapToInt(r -> r.getHeartRate() != null ? r.getHeartRate() : 0).average().orElse(0));
            stats.put("avgSleepHours", records.stream()
                    .map(r -> r.getSleepHours() != null ? r.getSleepHours() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add)
                    .divide(BigDecimal.valueOf(records.size()), 1, RoundingMode.HALF_UP));
            stats.put("avgWeight", records.stream()
                    .map(r -> r.getWeight() != null ? r.getWeight() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add)
                    .divide(BigDecimal.valueOf(records.size()), 1, RoundingMode.HALF_UP));
            stats.put("avgBloodSugar", records.stream()
                    .map(r -> r.getBloodSugar() != null ? r.getBloodSugar() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add)
                    .divide(BigDecimal.valueOf(records.size()), 1, RoundingMode.HALF_UP));
        } else {
            stats.put("avgSteps", 0);
            stats.put("avgHeartRate", 0);
            stats.put("avgSleepHours", 0);
            stats.put("avgWeight", 0);
            stats.put("avgBloodSugar", 0);
        }

        // 构建日期索引数据
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM-dd");
        Map<LocalDate, HealthData> dateMap = records.stream()
                .collect(Collectors.toMap(HealthData::getRecordDate, r -> r, (a, b) -> b));

        List<Integer> weeklySteps = new ArrayList<>();
        List<Integer> weeklyHeartRate = new ArrayList<>();
        List<Double> weeklySleep = new ArrayList<>();
        List<String> weekDates = new ArrayList<>();

        for (int i = 0; i < days; i++) {
            LocalDate date = startDate.plusDays(i);
            weekDates.add(date.format(formatter));
            HealthData rd = dateMap.get(date);
            weeklySteps.add(rd != null && rd.getSteps() != null ? rd.getSteps() : 0);
            weeklyHeartRate.add(rd != null && rd.getHeartRate() != null ? rd.getHeartRate() : 0);
            weeklySleep.add(rd != null && rd.getSleepHours() != null ? rd.getSleepHours().doubleValue() : 0);
        }

        stats.put("weeklySteps", weeklySteps);
        stats.put("weeklyHeartRate", weeklyHeartRate);
        stats.put("weeklySleep", weeklySleep);
        stats.put("weekDates", weekDates);

        // 月度体重
        List<Double> monthlyWeight = new ArrayList<>();
        List<String> monthDates = new ArrayList<>();
        for (HealthData r : records) {
            if (r.getWeight() != null && r.getWeight().compareTo(BigDecimal.ZERO) > 0) {
                monthlyWeight.add(r.getWeight().doubleValue());
                monthDates.add(r.getRecordDate().format(formatter));
            }
        }
        stats.put("monthlyWeight", monthlyWeight);
        stats.put("monthDates", monthDates);

        return stats;
    }

    /**
     * 导出健康数据
     */
    public Map<String, Object> exportData(Long userId, int days, String format) {
        LocalDate startDate = LocalDate.now().minusDays(days - 1);
        List<HealthData> records = healthDataMapper.selectByDateRange(userId, startDate);

        Map<String, Object> result = new HashMap<>();
        result.put("totalRecords", records.size());

        if ("csv".equalsIgnoreCase(format)) {
            StringBuilder csv = new StringBuilder();
            csv.append("日期,步数,心率(bpm),睡眠(h),体重(kg),收缩压(mmHg),舒张压(mmHg),血糖(mmol/L),热量(kcal),饮水(ml),心情\n");
            for (HealthData r : records) {
                csv.append(r.getRecordDate()).append(",")
                   .append(r.getSteps() != null ? r.getSteps() : 0).append(",")
                   .append(r.getHeartRate() != null ? r.getHeartRate() : 0).append(",")
                   .append(r.getSleepHours() != null ? r.getSleepHours() : 0).append(",")
                   .append(r.getWeight() != null ? r.getWeight() : 0).append(",")
                   .append(r.getSystolicBp() != null ? r.getSystolicBp() : 0).append(",")
                   .append(r.getDiastolicBp() != null ? r.getDiastolicBp() : 0).append(",")
                   .append(r.getBloodSugar() != null ? r.getBloodSugar() : 0).append(",")
                   .append(r.getCalories() != null ? r.getCalories() : 0).append(",")
                   .append(r.getWaterIntake() != null ? r.getWaterIntake() : 0).append(",")
                   .append(r.getMood() != null ? r.getMood() : 3).append("\n");
            }
            result.put("content", csv.toString());
            result.put("format", "csv");
        } else {
            // JSON 格式直接返回记录列表
            result.put("content", records);
            result.put("format", "json");
        }

        return result;
    }
}

