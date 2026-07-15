-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(128) NOT NULL COMMENT '密码（加密后）',
  `nickname` VARCHAR(50) DEFAULT '' COMMENT '昵称',
  `avatar` VARCHAR(255) DEFAULT '' COMMENT '头像URL',
  `gender` TINYINT DEFAULT 0 COMMENT '性别 0-未知 1-男 2-女',
  `age` INT DEFAULT 0 COMMENT '年龄',
  `height` DECIMAL(5,1) DEFAULT 0 COMMENT '身高(cm)',
  `weight` DECIMAL(5,1) DEFAULT 0 COMMENT '体重(kg)',
  `phone` VARCHAR(20) DEFAULT '' COMMENT '手机号',
  `email` VARCHAR(100) DEFAULT '' COMMENT '邮箱',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 0-正常 1-删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 健康数据表
CREATE TABLE IF NOT EXISTS `health_data` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `record_date` DATE NOT NULL COMMENT '记录日期',
  `steps` INT DEFAULT 0 COMMENT '步数',
  `heart_rate` INT DEFAULT 0 COMMENT '心率(次/分)',
  `sleep_hours` DECIMAL(3,1) DEFAULT 0 COMMENT '睡眠时长(小时)',
  `weight` DECIMAL(5,1) DEFAULT 0 COMMENT '体重(kg)',
  `systolic_bp` INT DEFAULT 0 COMMENT '收缩压(mmHg)',
  `diastolic_bp` INT DEFAULT 0 COMMENT '舒张压(mmHg)',
  `blood_sugar` DECIMAL(4,1) DEFAULT 0 COMMENT '血糖(mmol/L)',
  `calories` INT DEFAULT 0 COMMENT '热量消耗(kcal)',
  `water_intake` INT DEFAULT 0 COMMENT '饮水量(ml)',
  `mood` TINYINT DEFAULT 3 COMMENT '心情 1-5',
  `note` TEXT COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`, `record_date`),
  KEY `idx_record_date` (`record_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康数据表';

-- 提醒设置表
CREATE TABLE IF NOT EXISTS `reminder` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '提醒ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `reminder_type` VARCHAR(30) NOT NULL COMMENT '提醒类型：morning/water/exercise/sleep/medicine/measure',
  `label` VARCHAR(50) DEFAULT '' COMMENT '提醒标签',
  `description` VARCHAR(200) DEFAULT '' COMMENT '提醒描述',
  `icon` VARCHAR(10) DEFAULT '' COMMENT '图标',
  `reminder_time` VARCHAR(10) DEFAULT '08:00' COMMENT '提醒时间 HH:mm',
  `enabled` TINYINT DEFAULT 0 COMMENT '是否启用 0-关闭 1-开启',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='提醒设置表';

-- FAQ 帮助中心表
CREATE TABLE IF NOT EXISTS `faq` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'FAQ ID',
  `question` VARCHAR(200) NOT NULL COMMENT '问题',
  `answer` TEXT NOT NULL COMMENT '回答',
  `sort_order` INT DEFAULT 0 COMMENT '排序序号',
  `enabled` TINYINT DEFAULT 1 COMMENT '是否启用 0-禁用 1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='FAQ帮助中心表';

-- 初始化 FAQ 数据
INSERT INTO `faq` (`question`, `answer`, `sort_order`, `enabled`) VALUES
('如何记录每日健康数据？', '在首页点击"记录数据"按钮，进入数据录入页面，填写当天的步数、心率、睡眠时长等健康指标，点击提交即可保存。系统支持同日多次更新，最新数据会覆盖旧数据。', 1, 1),
('如何查看健康趋势图表？', '点击底部导航栏的"数据"标签页，即可查看最近 7 天或 30 天的各项健康指标趋势图，包括步数、心率、睡眠、体重等数据的变化曲线。', 2, 1),
('AI 健康助手能做什么？', 'AI 健康助手可以根据您的健康数据提供个性化的健康建议，包括饮食建议、运动方案、睡眠优化等。您可以直接向 AI 提问任何健康相关的问题。', 3, 1),
('如何导出我的健康数据？', '在"我的"页面中点击"数据导出"，选择导出格式（CSV 或 JSON）和时间范围，点击导出后数据会复制到剪贴板，您可以粘贴到备忘录或其他应用中。', 4, 1),
('如何设置健康提醒？', '在"我的"页面中点击"提醒设置"，可以开启或关闭各类提醒（如晨起打卡、喝水提醒、运动提醒等），并设置提醒时间。', 5, 1),
('我的数据安全吗？', '我们高度重视用户隐私和数据安全。所有数据均经过加密传输和存储，未经您的同意不会与任何第三方共享。您可以随时在个人中心删除自己的数据。', 6, 1),
('如何修改个人信息？', '在"我的"页面点击头像区域的"编辑"按钮，即可修改昵称、性别、年龄、身高、体重等基本信息。修改后点击保存即可生效。', 7, 1),
('遇到问题如何反馈？', '您可以通过 AI 助手描述您遇到的问题，或者发送邮件至 support@healthmanager.com 联系我们的客服团队，我们会在 24 小时内回复您。', 8, 1);

-- 应用信息配置表
CREATE TABLE IF NOT EXISTS `app_info` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` VARCHAR(50) NOT NULL COMMENT '配置键',
  `config_value` VARCHAR(500) DEFAULT '' COMMENT '配置值',
  `remark` VARCHAR(200) DEFAULT '' COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用信息配置表';

-- 初始化应用信息
INSERT INTO `app_info` (`config_key`, `config_value`, `remark`) VALUES
('appName', '健康管家', '应用名称'),
('appSlogan', 'AI 驱动的个人健康管理平台', '应用口号'),
('version', '1.0.0', '当前版本号'),
('email', 'support@healthmanager.com', '联系邮箱'),
('website', 'www.healthmanager.com', '官网地址'),
('address', '中国 · 深圳', '团队地址'),
('copyright', '© 2026 健康管家 All Rights Reserved', '版权信息'),
('techFrontend', 'Taro + React + TypeScript', '前端技术栈'),
('techBackend', 'Spring Boot + MyBatis-Plus', '后端技术栈'),
('techAi', 'GPT 大语言模型', 'AI 引擎'),
('techData', 'ECharts 可视化', '数据可视化');
