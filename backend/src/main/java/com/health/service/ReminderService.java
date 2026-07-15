package com.health.service;

import com.health.entity.Reminder;
import com.health.mapper.ReminderMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ReminderService {

    @Autowired
    private ReminderMapper reminderMapper;

    // 默认提醒模板
    private static final String[][] DEFAULT_REMINDERS = {
        {"morning", "🌅", "晨起打卡", "提醒您记录晨起健康数据", "07:00"},
        {"water", "💧", "喝水提醒", "定时提醒您补充水分", "09:00"},
        {"exercise", "🏃", "运动提醒", "提醒您进行适量运动", "18:00"},
        {"sleep", "🌙", "睡眠提醒", "提醒您准时就寝", "22:00"},
        {"medicine", "💊", "用药提醒", "提醒您按时服药", "08:00"},
        {"measure", "📏", "测量提醒", "提醒您测量血压/血糖", "07:30"},
    };

    /**
     * 获取用户的提醒列表，如果没有则初始化默认提醒
     */
    public List<Reminder> getUserReminders(Long userId) {
        List<Reminder> reminders = reminderMapper.selectByUserId(userId);
        if (reminders.isEmpty()) {
            reminders = initDefaultReminders(userId);
        }
        return reminders;
    }

    /**
     * 初始化默认提醒
     */
    private List<Reminder> initDefaultReminders(Long userId) {
        for (String[] def : DEFAULT_REMINDERS) {
            Reminder r = new Reminder();
            r.setUserId(userId);
            r.setReminderType(def[0]);
            r.setIcon(def[1]);
            r.setLabel(def[2]);
            r.setDescription(def[3]);
            r.setReminderTime(def[4]);
            r.setEnabled(def[0].equals("morning") || def[0].equals("water") || def[0].equals("sleep") ? 1 : 0);
            reminderMapper.insert(r);
        }
        return reminderMapper.selectByUserId(userId);
    }

    /**
     * 更新提醒
     */
    public void updateReminder(Long userId, Long reminderId, Reminder update) {
        Reminder existing = reminderMapper.selectById(reminderId);
        if (existing == null || !existing.getUserId().equals(userId)) {
            throw new RuntimeException("提醒不存在");
        }
        existing.setEnabled(update.getEnabled());
        existing.setReminderTime(update.getReminderTime());
        reminderMapper.updateById(existing);
    }

    /**
     * 批量更新提醒
     */
    public void batchUpdate(Long userId, List<Reminder> reminders) {
        for (Reminder r : reminders) {
            if (r.getId() != null) {
                updateReminder(userId, r.getId(), r);
            }
        }
    }
}
