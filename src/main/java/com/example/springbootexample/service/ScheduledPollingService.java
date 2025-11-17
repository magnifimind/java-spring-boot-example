package com.example.springbootexample.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class ScheduledPollingService {

    private static final Logger logger = LoggerFactory.getLogger(ScheduledPollingService.class);
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * Scheduled polling method that executes every 30 seconds.
     * Wrapped in a catch-all exception handler to prevent scheduling disruption.
     */
    @Scheduled(fixedRate = 30000, initialDelay = 10000)
    public void poll() {
        try {
            String timestamp = LocalDateTime.now().format(formatter);
            logger.info("Scheduled polling executed at: {}", timestamp);

            // Simulate some polling work
            logger.debug("Performing scheduled polling operations...");

            // Add your polling logic here
            // For example: check external resources, update caches, etc.

        } catch (Exception e) {
            // Catch all exceptions to ensure the scheduler continues running
            logger.error("Error during scheduled polling", e);
        }
    }
}
