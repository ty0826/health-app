package com.health.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class HealthDataRequest {
    private String recordDate;
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
}
