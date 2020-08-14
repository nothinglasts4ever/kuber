package com.example.demo;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(url = "${db-app.url}", name = "db-app")
public interface DbAppClient {

    @GetMapping
    String get();

}