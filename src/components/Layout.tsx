import { ReactNode } from "react";
import { Logo } from "./Logo";

interface LayoutProps {
  children: ReactNode;
  title?: string;
  showHeader?: boolean;
}

export const Layout = ({ children, title, showHeader = true }: LayoutProps) => {
  return (
    <div className="min-h-screen bg-white">
      {showHeader && (
        <header className="bg-white shadow-md border-b-2 border-institutional-gold">
          <div className="container mx-auto px-4 py-4">
            <div className="flex items-center justify-between">
              <Logo size="md" />
              {title && (
                <h1 className="text-2xl font-bold text-institutional-blue">{title}</h1>
              )}
            </div>
          </div>
        </header>
      )}
      <main className="container mx-auto px-4 py-8">
        {children}
      </main>
    </div>
  );
};