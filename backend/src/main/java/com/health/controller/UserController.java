package com.health.controller;

import com.health.dto.LoginRequest;
import com.health.dto.RegisterRequest;
import com.health.entity.User;
import com.health.service.UserService;
import com.health.vo.Result;
import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@Valid @RequestBody LoginRequest request) {
        Map<String, Object> data = userService.login(request);
        return Result.success(data);
    }

    @PostMapping("/register")
    public Result<Void> register(@Valid @RequestBody RegisterRequest request) {
        userService.register(request);
        return Result.success();
    }

    @GetMapping("/info")
    public Result<User> getUserInfo(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        User user = userService.getUserInfo(userId);
        return Result.success(user);
    }

    @PostMapping("/edit")
    public Result<Void> updateUserInfo1(HttpServletRequest request, @RequestBody User updateData) {
        Long userId = (Long) request.getAttribute("userId");
        userService.updateUserInfo(userId, updateData);
        return Result.success();
    }

}
