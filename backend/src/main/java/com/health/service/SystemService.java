package com.health.service;

import com.health.entity.AppInfo;
import com.health.entity.Faq;
import com.health.mapper.AppInfoMapper;
import com.health.mapper.FaqMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SystemService {

    @Autowired
    private FaqMapper faqMapper;

    @Autowired
    private AppInfoMapper appInfoMapper;

    /**
     * 获取启用的 FAQ 列表
     */
    public List<Faq> getFaqList() {
        return faqMapper.selectEnabledList();
    }

    /**
     * 获取应用信息（key-value 形式）
     */
    public Map<String, String> getAppInfo() {
        List<AppInfo> list = appInfoMapper.selectAllInfo();
        Map<String, String> result = new HashMap<>();
        for (AppInfo info : list) {
            result.put(info.getConfigKey(), info.getConfigValue());
        }

        // 设置默认值（如果数据库未配置）
        result.putIfAbsent("appName", "健康管家");
        result.putIfAbsent("appSlogan", "AI 驱动的个人健康管理平台");
        result.putIfAbsent("version", "1.0.0");
        result.putIfAbsent("email", "support@healthmanager.com");
        result.putIfAbsent("website", "www.healthmanager.com");
        result.putIfAbsent("address", "中国 · 深圳");
        result.putIfAbsent("copyright", "© 2026 健康管家 All Rights Reserved");

        return result;
    }
}
