package com.stalin.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.boot.builder.SpringApplicationBuilder;

@SpringBootApplication
// 1. EXTEND SpringBootServletInitializer
public class DemoWorkshopApplication extends SpringBootServletInitializer {

    // 2. OVERRIDE the configure builder method for external servers
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(DemoWorkshopApplication.class);
    }

    // Keep your regular main method below so it can still run locally as a JAR
    public static void main(String[] args) {
        SpringApplication.run(DemoWorkshopApplication.class, args);
    }
}
