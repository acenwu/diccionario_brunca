import { useNavigate, useSearchParams } from "react-router";
import { ArrowLeft, Search } from "lucide-react";

// Mock Results
const mockResults = [
  { id: "1", word: "Aúj", matches: "Perro" },
  { id: "2", word: "Bís", matches: "Gato" },
  { id: "3", word: "Cratus", matches: "Pato" },
  { id: "4", word: "Turí", matches: "Vaca" },
  { id: "5", word: "Sárocra", matches: "Caballo" },
  { id: "6", word: "Cró", matches: "Gallina" },
  { id: "7", word: "Cuchi", matches: "Cerdo" },
  { id: "8", word: "Dibí Cun", matches: "Chompipe" },
];

export function SearchResults() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const query = searchParams.get("q") || "";

  // Filter results based on query
  const results = mockResults.filter((item) =>
    item.word.toLowerCase().includes(query.toLowerCase()) ||
    item.matches.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Header */}
      <header className="border-b-2 border-gray-900 bg-white p-4 flex items-center gap-4">
        <button
          onClick={() => navigate("/")}
          className="p-2 border-2 border-gray-900"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>

        <h1 className="text-xl font-mono">
          RESULTADOS DE BÚSQUEDA
        </h1>
      </header>

      {/* Search Bar */}
      <div className="border-b-2 border-gray-900 bg-white p-4">
        <div className="flex items-center gap-2 border-2 border-gray-900 p-3 bg-gray-100">
          <Search className="w-5 h-5" />
          <span className="font-mono">
            {query || "Buscar palabra"}
          </span>
        </div>
      </div>

      {/* Results List */}
      <main className="flex-1 p-4">
        <div className="max-w-md mx-auto space-y-2">

          <p className="text-sm font-mono text-gray-600 mb-4">
            {results.length} resultados encontrados
          </p>

          {results.length > 0 ? (
            results.map((result) => (
              <button
                key={result.id}
                onClick={() => navigate(`/word/${result.id}`)}
                className="w-full p-4 border-2 border-gray-900 bg-white hover:bg-gray-100 text-left"
              >
                <div className="flex justify-between items-start">
                  
                  <div className="flex-1">

                    {/* Spanish Word */}
                    <div className="text-sm text-gray-500 font-mono mb-1">
                      Español
                    </div>

                    <div className="font-mono text-xl mb-3">
                      {result.matches}
                    </div>

                    {/* Brunca Translation */}
                    <div className="text-sm text-gray-500 font-mono mb-1">
                      Brunca
                    </div>

                    <div className="font-mono text-lg text-blue-600">
                      → {result.word}
                    </div>

                  </div>

                  <div className="w-8 h-8 border-2 border-gray-900 flex items-center justify-center ml-4">
                    →
                  </div>

                </div>
              </button>
            ))
          ) : (
            <div className="p-8 border-2 border-dashed border-gray-400 text-center">
              <p className="font-mono text-gray-500">
                No se encontraron resultados
              </p>
            </div>
          )}

          {/* Wireframe Notes */}
          <div className="mt-8 p-4 border-2 border-dashed border-gray-400">
            <p className="text-xs font-mono text-gray-500">
              [WIREFRAME] Pantalla de Resultados de Búsqueda
              <br />- Búsqueda de palabras
              <br />- Navegación hacia detalles de palabra
              <br />- Compatibilidad con búsqueda bidireccional
            </p>
          </div>

        </div>
      </main>
    </div>
  );
}
