import React, { useMemo } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Dumbbell, Apple, PenTool } from 'lucide-react';

interface FloatingActionMenuProps {
  isOpen: boolean;
  onClose: () => void;
}

export const FloatingActionMenu = React.memo(function FloatingActionMenu({ isOpen, onClose }: FloatingActionMenuProps) {
  const menuItems = useMemo(() => [
    { icon: Dumbbell, label: '发布训练', color: 'bg-blue-500' },
    { icon: Apple, label: '发布饮食', color: 'bg-green-500' },
    { icon: PenTool, label: '发布动态', color: 'bg-purple-500' },
  ], []);

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black bg-opacity-50 z-40"
            onClick={onClose}
          />
          <motion.div
            initial={{ opacity: 0, scale: 0.8, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.8, y: 20 }}
            className="fixed bottom-20 left-1/2 transform -translate-x-1/2 z-50"
          >
            <div className="bg-white rounded-2xl shadow-xl p-4 min-w-[280px]">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg text-gray-900">发布内容</h3>
                <button
                  onClick={onClose}
                  className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center"
                >
                  <X className="w-4 h-4 text-gray-600" />
                </button>
              </div>
              <div className="space-y-3">
                {menuItems.map((item, index) => (
                  <motion.button
                    key={index}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1 }}
                    className="w-full flex items-center space-x-3 p-3 rounded-xl hover:bg-gray-50 transition-colors"
                    onClick={onClose}
                  >
                    <div className={`w-10 h-10 ${item.color} rounded-full flex items-center justify-center`}>
                      <item.icon className="w-5 h-5 text-white" />
                    </div>
                    <span className="text-gray-900">{item.label}</span>
                  </motion.button>
                ))}
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
});