package com.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.health.entity.HealthData;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface HealthDataMapper extends BaseMapper<HealthData> {

    @Select("SELECT * FROM health_data WHERE user_id = #{userId} AND record_date >= #{startDate} AND deleted = 0 ORDER BY record_date ASC")
    List<HealthData> selectByDateRange(@Param("userId") Long userId, @Param("startDate") LocalDate startDate);

    @Select("SELECT * FROM health_data WHERE user_id = #{userId} AND record_date = #{date} AND deleted = 0 LIMIT 1")
    HealthData selectByUserAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);
}
