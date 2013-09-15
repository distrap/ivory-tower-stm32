// -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4 -*-
/*
 * Copyright (C) 2013, Galois, Inc.
 * All Rights Reserved.
 *
 * This software is released under the "BSD3" license.  Read the file
 * "LICENSE" for more information.
 */

#include <stdint.h>

#include <FreeRTOS.h>
#include <task.h>

extern void test_task(void);

void main_task(void *arg)
{
    test_task();
    for (;;) {}
}

int main()
{
    xTaskCreate(main_task, (signed char *)"main", 256, NULL, 0, NULL);
    vTaskStartScheduler();

    for (;;)
        ;

    return 0;
}
