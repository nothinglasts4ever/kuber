package com.example.demo;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class TheController {

    private final TheRepository repository;

    @Value("${app.message:default details}")
    private String messageDetails;

    @GetMapping
    public String get() {
        return UUID.randomUUID().toString() + " " + messageDetails;
    }

    @PostMapping
    public TheEntity create() {
        TheEntity entity = new TheEntity();
        entity.setId(UUID.randomUUID());
        entity.setName("Random name " + UUID.randomUUID() + " with details: " + messageDetails);
        return repository.save(entity);
    }

}