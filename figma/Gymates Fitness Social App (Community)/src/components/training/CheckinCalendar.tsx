import { useState } from 'react';
import { Calendar, CalendarDays } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

export function CheckinCalendar() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [selectedDate, setSelectedDate] = useState(new Date());

  // Mock data for training days
  const trainingDays = [1, 3, 5, 8, 10, 12, 15, 17, 20, 22, 25];
  
  const getCurrentMonth = () => {
    const today = new Date();
    const year = today.getFullYear();
    const month = today.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startDayOfWeek = firstDay.getDay();
    
    const days = [];
    
    // Add empty cells for days before the first day of the month
    for (let i = 0; i < startDayOfWeek; i++) {
      days.push(null);
    }
    
    // Add all days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      days.push(day);
    }
    
    return { days, monthName: today.toLocaleDateString('zh-CN', { month: 'long', year: 'numeric' }) };
  };

  const { days, monthName } = getCurrentMonth();
  const weekDays = ['日', '一', '二', '三', '四', '五', '六'];

  return (
    <div className={`bg-white rounded-${isIOS ? '3xl' : '2xl'} p-4 mb-6 border border-gray-200`}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <Calendar className="w-5 h-5 text-primary" />
          <h3 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>打卡日历</h3>
        </div>
        <span className="text-sm text-gray-600">{monthName}</span>
      </div>

      {/* Week days header */}
      <div className="grid grid-cols-7 gap-1 mb-2">
        {weekDays.map((day) => (
          <div key={day} className="text-center py-2">
            <span className="text-xs text-gray-500">{day}</span>
          </div>
        ))}
      </div>

      {/* Calendar grid */}
      <div className="grid grid-cols-7 gap-1">
        {days.map((day, index) => {
          const isTrainingDay = day && trainingDays.includes(day);
          const isToday = day === new Date().getDate();
          
          return (
            <div
              key={index}
              className={`aspect-square flex items-center justify-center text-sm relative ${
                day ? 'cursor-pointer' : ''
              }`}
            >
              {day && (
                <>
                  <span className={`
                    ${isToday ? 'text-white' : isTrainingDay ? 'text-primary' : 'text-gray-600'}
                    ${isToday ? 'font-semibold' : ''}
                  `}>
                    {day}
                  </span>
                  
                  {/* Today indicator */}
                  {isToday && (
                    <div className="absolute inset-0 bg-primary rounded-full" style={{ zIndex: -1 }} />
                  )}
                  
                  {/* Training day indicator */}
                  {isTrainingDay && !isToday && (
                    <div className="absolute bottom-1 w-1 h-1 bg-primary rounded-full" />
                  )}
                </>
              )}
            </div>
          );
        })}
      </div>

      {/* Stats */}
      <div className="mt-4 pt-4 border-t border-gray-100 flex items-center justify-between">
        <div className="text-center">
          <p className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>12</p>
          <p className="text-xs text-gray-600">本月训练</p>
        </div>
        <div className="text-center">
          <p className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-green-600`}>75%</p>
          <p className="text-xs text-gray-600">完成率</p>
        </div>
        <div className="text-center">
          <p className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-orange-600`}>5</p>
          <p className="text-xs text-gray-600">连续天数</p>
        </div>
      </div>
    </div>
  );
}