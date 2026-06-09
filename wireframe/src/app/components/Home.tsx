import { useState } from "react";
import { useNavigate } from "react-router";
import { Search, Heart } from "lucide-react";

export function Home() {
  const [searchQuery, setSearchQuery] = useState("");
  const navigate = useNavigate();

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      navigate(`/search?q=${encodeURIComponent(searchQuery)}`);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Header */}
      <header className="border-b-2 border-gray-900 bg-white p-4 flex justify-between items-center">
        <h1 className="text-xl font-mono">DICCIONARIO BRUNCA</h1>
        <button
          onClick={() => navigate("/favorites")}
          className="p-2 border-2 border-gray-900"
        >
          <Heart className="w-5 h-5" />
        </button>
      </header>

      {/* Main Content */}
      <main className="flex-1 flex flex-col items-center justify-center p-6">
        <div className="w-full max-w-md">
          {/* Logo/Title Area */}
          <div className="mb-12 text-center">
            <div className="w-24 h-24 mx-auto mb-4 border-4 border-gray-900 flex items-center justify-center">
              <Search className="w-12 h-12" />
            </div>
            <h2 className="text-2xl font-mono mb-2">Español → Brunca</h2>
            <p className="text-gray-600 font-mono text-sm">Aplicación Diccionario</p>
          </div>

          {/* Search Form */}
          <form onSubmit={handleSearch} className="space-y-4">
            <div className="border-2 border-gray-900 bg-white">
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar palabra..."
                className="w-full p-4 font-mono outline-none"
              />
            </div>
            <button
              type="submit"
              className="w-full p-4 bg-gray-900 text-white font-mono border-2 border-gray-900 hover:bg-gray-800"
            >
              BÚSQUEDA
            </button>
          </form>

          {/* Wireframe Notes */}
          <div className="mt-8 p-4 border-2 border-dashed border-gray-400">
            <p className="text-xs font-mono text-gray-500">
              [WIREFRAME] Pantalla de Inicio
              <br />- Barra de búsqueda para palabras
              <br />- Botón de favoritos en esquina
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}
