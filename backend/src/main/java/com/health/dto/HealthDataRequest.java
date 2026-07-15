package com.health.dto;

import lombok.Data;
import java.math.BigDecimal;
import javax.validation.constraints.DecimalMax;
import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

@Data
public class HealthDataRequest {
    @Pattern(regexp = "^\\d{4}-\\d{2}-\\d{2}$", message = "日期格式必须为 yyyy-MM-dd")
    private String recordDate;

    @Min(value = 0, message = "步数不能小于 0")
    @Max(value = 200000, message = "步数不能超过 200000")
    private Integer steps;

    @Min(value = 20, message = "心率不能低于 20")
    @Max(value = 250, message = "心率不能高于 250")
    private Integer heartRate;

    @DecimalMin(value = "0.0", message = "睡眠时长不能小于 0")
    @DecimalMax(value = "24.0", message = "睡眠时长不能超过 24")
    private BigDecimal sleepHours;

    @DecimalMin(value = "1.0", message = "体重不能低于 1 kg")
    @DecimalMax(value = "500.0", message = "体重不能超过 500 kg")
    private BigDecimal weight;

    @Min(value = 40, message = "收缩压不能低于 40")
    @Max(value = 300, message = "收缩压不能超过 300")
    private Integer systolicBp;

    @Min(value = 30, message = "舒张压不能低于 30")
    @Max(value = 200, message = "舒张压不能超过 200")
    private Integer diastolicBp;

    @DecimalMin(value = "0.1", message = "血糖不能低于 0.1")
    @DecimalMax(value = "50.0", message = "血糖不能超过 50")
    private BigDecimal bloodSugar;

    @Min(value = 0, message = "热量不能小于 0")
    @Max(value = 20000, message = "热量不能超过 20000")
    private Integer calories;

    @Min(value = 0, message = "饮水量不能小于 0")
    @Max(value = 20000, message = "饮水量不能超过 20000")
    private Integer waterIntake;

    @Min(value = 1, message = "心情值不能低于 1")
    @Max(value = 5, message = "心情值不能超过 5")
    private Integer mood;

    @Size(max = 500, message = "备注不能超过 500 个字符")
    private String note;
}
