package com.example.springbootexample.controller;

import com.example.springbootexample.model.HelloResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class HelloControllerTest {

    @Autowired
    private HelloController helloController;

    @Test
    void testGetHello_returnsOkStatus() {
        // When
        ResponseEntity<HelloResponse> response = helloController.getHello();

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    @Test
    void testGetHello_returnsWorld() {
        // When
        ResponseEntity<HelloResponse> response = helloController.getHello();

        // Then
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getMessage()).isEqualTo("world");
    }

    @Test
    void testGetHello_messageIsNotEmpty() {
        // When
        ResponseEntity<HelloResponse> response = helloController.getHello();

        // Then
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getMessage())
                .isNotNull()
                .isNotEmpty()
                .isNotBlank();
    }
}
