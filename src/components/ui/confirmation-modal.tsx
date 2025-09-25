import React from 'react';
import { CheckCircle, X } from 'lucide-react';

interface ConfirmationModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  message: string;
  type?: 'success' | 'error' | 'info';
}

export const ConfirmationModal: React.FC<ConfirmationModalProps> = ({
  isOpen,
  onClose,
  title,
  message,
  type = 'success'
}) => {
  if (!isOpen) return null;

  const getIconColor = () => {
    switch (type) {
      case 'success': return 'text-green-500';
      case 'error': return 'text-red-500';
      case 'info': return 'text-blue-500';
      default: return 'text-green-500';
    }
  };

  const getIcon = () => {
    switch (type) {
      case 'success': return <CheckCircle className="w-8 h-8" />;
      case 'error': return <X className="w-8 h-8" />;
      case 'info': return <CheckCircle className="w-8 h-8" />;
      default: return <CheckCircle className="w-8 h-8" />;
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-lg p-6 max-w-md w-full mx-4">
        <div className="flex items-center justify-between mb-4">
          <div className={`flex items-center gap-3 ${getIconColor()}`}>
            {getIcon()}
            <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        
        <p className="text-gray-700 mb-6">{message}</p>
        
        <div className="flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-institutional-gold text-institutional-blue font-semibold rounded-lg hover:bg-institutional-gold/90 transition-colors"
          >
            Entendi
          </button>
        </div>
      </div>
    </div>
  );
};
