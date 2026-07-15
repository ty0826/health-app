package com.health.controller;

import com.health.entity.Reminder;
import com.health.service.ReminderService;
import com.health.vo.Result;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reminder")
public class ReminderController {

    @Autowired
    private ReminderService reminderService;

    /**
     * 获取用户提醒列表
     */
    @GetMapping("/list")
    public Result<List<Reminder>> getReminders(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        List<Reminder> reminders = reminderService.getUserReminders(userId);
        return Result.success(reminders);
    }

    /**
     * 更新单个提醒
     */
    @PutMapping("/{id}")
    public Result<Void> updateReminder(
            HttpServletRequest request,
            @PathVariable Long id,
            @RequestBody Reminder update) {
        Long userId = (Long) request.getAttribute("userId");
        reminderService.updateReminder(userId, id, update);
        return Result.success();
    }

    /**
     * 批量更新提醒
     */
    @PutMapping("/batch")
    public Result<Void> batchUpdate(
            HttpServletRequest request,
            @RequestBody List<Reminder> reminders) {
        Long userId = (Long) request.getAttribute("userId");
        reminderService.batchUpdate(userId, reminders);
        return Result.success();
    }
}
