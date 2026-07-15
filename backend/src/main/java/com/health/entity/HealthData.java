package com.health.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("health_data")
public class HealthData {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private LocalDate recordDate;

    private Integer steps;

    private Integer heartRate;

    private BigDecimal sleepHours;

    private BigDecimal weight;

    private Integer systolicBp;

    private Integer diastolicBp;

    private BigDecimal bloodSugar;

    private Integer calories;

    private Integer waterIntake;

    private Integer mood;

    private String note;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableLogic
    private Integer deleted;
}
