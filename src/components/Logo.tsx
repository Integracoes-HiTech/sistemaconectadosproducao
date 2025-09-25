import { Users, Zap, Network } from "lucide-react";

interface LogoProps {
  size?: "sm" | "md" | "lg";
  showText?: boolean;
  layout?: "horizontal" | "vertical";
  textColor?: "blue" | "white" | "gold";
}

export const Logo = ({ 
  size = "md", 
  showText = true, 
  layout = "horizontal",
  textColor = "blue"
}: LogoProps) => {
  const sizeClasses = {
    sm: "w-8 h-8",
    md: "w-12 h-12", 
    lg: "w-16 h-16"
  };

  const textSizeClasses = {
    sm: "text-sm",
    md: "text-lg",
    lg: "text-2xl"
  };

  const textColorClasses = {
    blue: "text-institutional-blue",
    white: "text-white",
    gold: "text-institutional-gold"
  };

  const containerClasses = layout === "horizontal" 
    ? "flex items-center gap-3" 
    : "flex flex-col items-center gap-3";

  const textContainerClasses = layout === "horizontal" 
    ? "flex flex-col" 
    : "flex flex-col items-center";

  return (
    <div className={containerClasses}>
      {/* Logo moderno com gradiente e ícones conectados */}
      <div className={`${sizeClasses[size]} relative bg-gradient-to-br from-institutional-gold to-yellow-400 rounded-xl p-2 shadow-lg`}>
        {/* Ícone principal - Rede de conexões */}
        <Network className="w-full h-full text-institutional-blue" />
        
        {/* Elementos de conexão */}
        <div className="absolute -top-1 -right-1 w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
        <div className="absolute -bottom-1 -left-1 w-2 h-2 bg-blue-500 rounded-full"></div>
        <div className="absolute top-0 left-0 w-1 h-1 bg-purple-500 rounded-full"></div>
        
        {/* Efeito de brilho */}
        <div className="absolute inset-0 bg-gradient-to-br from-white/20 to-transparent rounded-xl"></div>
      </div>
      
      {showText && (
        <div className={textContainerClasses}>
          <span className={`${textSizeClasses[size]} font-black ${textColorClasses[textColor]} leading-tight tracking-tight`}>
            CONECTADOS
          </span>
          <span className={`text-xs font-medium ${textColorClasses[textColor]} opacity-80 tracking-wider uppercase`}>
            Sistema de Gestão
          </span>
        </div>
      )}
    </div>
  );
};