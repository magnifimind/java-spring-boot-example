package com.example.springbootexample.controller;

import static org.assertj.core.api.Assertions.assertThat;

import com.example.springbootexample.model.HealthResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@SpringBootTest
class HealthControllerTest {

  @Autowired private HealthController healthController;

  @Test
  void testGetHealth_returnsOkStatus() {
    // When
    ResponseEntity<HealthResponse> response = healthController.getHealth();

    // Then
    assertThat(response).isNotNull();
    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
  }

  @Test
  void testGetHealth_returnsHealthResponse() {
    // When
    ResponseEntity<HealthResponse> response = healthController.getHealth();

    // Then
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().getStatus()).isEqualTo("UP");
    assertThat(response.getBody().getTimestamp()).isNotNull();
    assertThat(response.getBody().getMessage()).isEqualTo("Service is running normally");
  }

  @Test
  void testGetHealth_timestampIsRecent() {
    // When
    ResponseEntity<HealthResponse> response = healthController.getHealth();

    // Then
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().getTimestamp()).isNotNull();
    // Timestamp should be within the last minute
    assertThat(response.getBody().getTimestamp())
        .isAfterOrEqualTo(java.time.OffsetDateTime.now().minusMinutes(1));
  }
}
