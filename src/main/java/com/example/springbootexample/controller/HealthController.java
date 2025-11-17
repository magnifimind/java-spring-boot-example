package com.example.springbootexample.controller;

import com.example.springbootexample.api.HealthApi;
import com.example.springbootexample.model.ErrorResponse;
import com.example.springbootexample.model.HealthResponse;
import java.time.OffsetDateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController implements HealthApi {

  private static final Logger logger = LoggerFactory.getLogger(HealthController.class);

  @Override
  public ResponseEntity<HealthResponse> getHealth() {
    try {
      logger.debug("Health check endpoint called");

      HealthResponse response = new HealthResponse();
      response.setStatus("UP");
      response.setTimestamp(OffsetDateTime.now());
      response.setMessage("Service is running normally");

      logger.debug("Health check successful");
      return ResponseEntity.ok(response);

    } catch (Exception e) {
      logger.error("Error during health check", e);

      ErrorResponse errorResponse = new ErrorResponse();
      errorResponse.setError("Health check failed");
      errorResponse.setTimestamp(OffsetDateTime.now());
      errorResponse.setDetails(e.getMessage());

      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
    }
  }
}
