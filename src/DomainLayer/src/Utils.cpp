#include "DomainLayer/Utils.hpp"


std::chrono::system_clock::time_point changeTime(std::chrono::system_clock::time_point &time, int hour, int min, int sec) {
    std::time_t now_time = std::chrono::system_clock::to_time_t(time);
    std::tm now_tm = *std::localtime(&now_time);

    std::tm midnight_tm = now_tm;
    if (hour != -1) {
        midnight_tm.tm_hour = hour;
    }
    if (min != -1) {
        midnight_tm.tm_min = min;
    }
    if (sec != -1) {
        midnight_tm.tm_sec = sec;
    }
    
    return std::chrono::system_clock::from_time_t(std::mktime(&midnight_tm));
}