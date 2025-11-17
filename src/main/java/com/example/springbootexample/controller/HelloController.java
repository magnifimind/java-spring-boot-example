package com.example.springbootexample.controller;

import com.example.springbootexample.api.HelloApi;
import com.example.springbootexample.model.ErrorResponse;
import com.example.springbootexample.model.HelloResponse;
import java.time.OffsetDateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController implements HelloApi {

  private static final Logger logger = LoggerFactory.getLogger(HelloController.class);

  @Override
  public ResponseEntity<HelloResponse> getHello() {
    try {
      logger.debug("Hello endpoint called");

      HelloResponse response = new HelloResponse();
      response.setMessage("world");

      logger.debug("Hello endpoint returned successfully");
      return ResponseEntity.ok(response);

    } catch (Exception e) {
      logger.error("Error in hello endpoint", e);

      ErrorResponse errorResponse = new ErrorResponse();
      errorResponse.setError("Failed to process hello request");
      errorResponse.setTimestamp(OffsetDateTime.now());
      errorResponse.setDetails(e.getMessage());

      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
    }
  }
}
