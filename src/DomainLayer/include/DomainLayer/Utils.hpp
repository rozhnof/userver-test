#pragma once

#include <chrono>

std::chrono::system_clock::time_point changeTime(std::chrono::system_clock::time_point &time, int hour = -1, int min = -1, int sec = -1);