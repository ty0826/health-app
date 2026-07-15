package com.health.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("reminder")
public class Reminder {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    /** 提醒类型：morning/water/exercise/sleep/medicine/measure */
    private String reminderType;

    /** 提醒标签 */
    private String label;

    /** 提醒描述 */
    private String description;

    /** 提醒图标 */
    private String icon;

    /** 提醒时间 HH:mm */
    private String reminderTime;

    /** 是否启用 0-关闭 1-开启 */
    private Integer enabled;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableLogic
    private Integer deleted;
}
