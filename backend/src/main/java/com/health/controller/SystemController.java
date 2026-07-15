package com.health.controller;

import com.health.entity.Faq;
import com.health.service.SystemService;
import com.health.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/system")
public class SystemController {

    @Autowired
    private SystemService systemService;

    /**
     * 获取 FAQ 列表
     */
    @GetMapping("/faq")
    public Result<List<Faq>> getFaqList() {
        List<Faq> list = systemService.getFaqList();
        return Result.success(list);
    }

    /**
     * 获取应用信息
     */
    @GetMapping("/app-info")
    public Result<Map<String, String>> getAppInfo() {
        Map<String, String> info = systemService.getAppInfo();
        return Result.success(info);
    }
}
