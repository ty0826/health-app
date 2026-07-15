package com.health.controller;

import com.health.dto.HealthDataRequest;
import com.health.entity.HealthData;
import com.health.service.HealthDataService;
import com.health.vo.Result;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class HealthDataController {

    @Autowired
    private HealthDataService healthDataService;

    @PostMapping("/record")
    public Result<Void> addRecord(HttpServletRequest request, @RequestBody HealthDataRequest healthDataRequest) {
        Long userId = (Long) request.getAttribute("userId");
        healthDataService.addRecord(userId, healthDataRequest);
        return Result.success();
    }

    @GetMapping("/list")
    public Result<List<HealthData>> getRecordList(
            HttpServletRequest request,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        Long userId = (Long) request.getAttribute("userId");
        List<HealthData> list = healthDataService.getRecordList(userId, page, size);
        return Result.success(list);
    }

    @GetMapping("/today")
    public Result<HealthData> getTodayRecord(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        HealthData data = healthDataService.getTodayRecord(userId);
        return Result.success(data);
    }

    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats(
            HttpServletRequest request,
            @RequestParam(defaultValue = "7") int days) {
        Long userId = (Long) request.getAttribute("userId");
        Map<String, Object> stats = healthDataService.getStats(userId, days);
        return Result.success(stats);
    }

    /**
     * 导出健康数据
     */
    @GetMapping("/export")
    public Result<Map<String, Object>> exportData(
            HttpServletRequest request,
            @RequestParam(defaultValue = "30") int days,
            @RequestParam(defaultValue = "csv") String format) {
        Long userId = (Long) request.getAttribute("userId");
        Map<String, Object> exportResult = healthDataService.exportData(userId, days, format);
        return Result.success(exportResult);
    }
}

