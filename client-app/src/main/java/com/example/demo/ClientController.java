package com.example.demo;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ClientController {

    private final DbAppClient discoveryClient;

    @GetMapping
    public String get() {
        return "Got from DB app: " + discoveryClient.get();
    }

}