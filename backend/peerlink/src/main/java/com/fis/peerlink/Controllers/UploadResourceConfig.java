package com.fis.peerlink.Controllers;

import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class UploadResourceConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {

        Path uploadPath = Paths.get("uploads", "profile-images")
                .toAbsolutePath()
                .normalize();

        String location = uploadPath.toUri().toString();

        registry.addResourceHandler("/uploads/profile-images/**")
                .addResourceLocations(location);
    }
}
