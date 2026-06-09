import { useNavigate } from "react-router";
import { ArrowLeft, Heart, Trash2 } from "lucide-react";

// Mock favorites data
const mockFavorites = [
  { id: "1", word: "Aúj", spanish: "Perro" },
  { id: "2", word: "Bís", spanish: "Gato" },
  { id: "3", word: "Sárocra", spanish: "Caballo" },
];

export function Favorites() {
  const navigate = useNavigate();

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

        <h1 className="text-xl font-mono flex items-center gap-2">
          <Heart className="w-5 h-5 fill-gray-900" />
          FAVORITOS
        </h1>

      </header>

      {/* Favorites List */}
      <main className="flex-1 p-4">

        <div className="max-w-md mx-auto space-y-2">

          <p className="text-sm font-mono text-gray-600 mb-4">
            {mockFavorites.length} palabras guardadas
          </p>

          {mockFavorites.length > 0 ? (

            mockFavorites.map((item) => (

              <div
                key={item.id}
                className="border-2 border-gray-900 bg-white p-4 flex items-center justify-between"
              >

                <button
                  onClick={() => navigate(`/word/${item.id}`)}
                  className="flex-1 text-left"
                >

                  {/* Spanish */}
                  <div className="text-sm text-gray-500 font-mono mb-1">
                    Español
                  </div>

                  <div className="font-mono text-xl mb-3">
                    {item.spanish}
                  </div>

                  {/* Brunca */}
                  <div className="text-sm text-gray-500 font-mono mb-1">
                    Brunca
                  </div>

                  <div className="font-mono text-lg text-blue-600">
                    → {item.word}
                  </div>

                </button>

                <button className="p-2 border-2 border-gray-900 hover:bg-gray-100 ml-4">
                  <Trash2 className="w-5 h-5" />
                </button>

              </div>

            ))

          ) : (

            <div className="p-12 border-2 border-dashed border-gray-400 text-center">

              <Heart className="w-12 h-12 mx-auto mb-4 text-gray-400" />

              <p className="font-mono text-gray-500">
                Aún no hay favoritos
              </p>

              <p className="text-sm font-mono text-gray-400 mt-2">
                Guarda palabras para revisarlas después
              </p>

            </div>

          )}

          {/* Wireframe Notes */}
          <div className="mt-8 p-4 border-2 border-dashed border-gray-400">

            <p className="text-xs font-mono text-gray-500">
              [WIREFRAME] Pantalla de Favoritos
              <br />- Lista de palabras guardadas
              <br />- Navegación hacia detalles de palabra
              <br />- Eliminación individual de favoritos
            </p>

          </div>

        </div>

      </main>

    </div>
  );
}
