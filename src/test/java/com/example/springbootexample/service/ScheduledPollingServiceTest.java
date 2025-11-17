package com.example.springbootexample.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThatCode;

@SpringBootTest
class ScheduledPollingServiceTest {

    @Autowired
    private ScheduledPollingService scheduledPollingService;

    @Test
    void testPoll_executesWithoutException() {
        // When/Then - should not throw any exception
        assertThatCode(() -> scheduledPollingService.poll())
                .doesNotThrowAnyException();
    }

    @Test
    void testPoll_canBeCalledMultipleTimes() {
        // When/Then - should handle multiple invocations
        assertThatCode(() -> {
            scheduledPollingService.poll();
            scheduledPollingService.poll();
            scheduledPollingService.poll();
        }).doesNotThrowAnyException();
    }
}
