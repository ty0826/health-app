package com.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.health.entity.AppInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface AppInfoMapper extends BaseMapper<AppInfo> {

    @Select("SELECT * FROM app_info ORDER BY id ASC")
    List<AppInfo> selectAllInfo();
}
