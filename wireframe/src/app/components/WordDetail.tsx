import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { ArrowLeft, Heart, Volume2 } from "lucide-react";

// Mock word data
const mockWords: Record<string, any> = {
  "1": {
    word: "Aúj",
    spanish: "Perro",
    category: "Animal",
    description: "Animal doméstico.",
    examples: [
      "El perro corre rápido.",
      "[Ejemplo en Brunca pendiente de validación]"
    ],
  },

  "2": {
    word: "Bís",
    spanish: "Gato",
    category: "Animal",
    description: "Animal doméstico felino.",
    examples: [
      "El gato duerme en la casa.",
      "[Ejemplo en Brunca pendiente de validación]"
    ],
  },

  "3": {
    word: "Cratus",
    spanish: "Pato",
    category: "Animal",
    description: "Ave acuática.",
    examples: [
      "El pato nada en el agua.",
      "[Ejemplo en Brunca pendiente de validación]"
    ],
  },

  "4": {
    word: "Turí",
    spanish: "Vaca",
    category: "Animal",
    description: "Animal de granja.",
    examples: [
      "La vaca come pasto.",
      "[Ejemplo en Brunca pendiente de validación]"
    ],
  },

  "5": {
    word: "Sárocra",
    spanish: "Caballo",
    category: "Animal",
    description: "Animal utilizado para transporte y trabajo.",
    examples: [
      "El caballo corre rápido.",
      "[Ejemplo en Brunca pendiente de validación]"
    ],
  },

  "6": {
    word: "Cró",
    spanish: "Gallina",
    category: "Animal",
    description: "Ave doméstica.",
    examples: [
      "La gallina pone huevos.",
      "[Ejemplo en Brunca pendiente de validación]"
    ],
  },

  "7": {
    word: "Cuchi",
    spanish: "Cerdo",
    category: "Animal",
    description: "Animal de granja.",
    examples: [
      "El cerdo vive en la granja.",
      "[Ejemplo en Brunca pendiente de validación]"
    ],
  },

  "8": {
    word: "Dibí Cun",
    spanish: "Chompipe",
    category: "Animal",
    description: "Ave doméstica.",
    examples: [
      "El chompipe camina por el patio.",
      "[Ejemplo en Brunca pendiente de validación]"
    ],
  },
};

export function WordDetail() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [isFavorite, setIsFavorite] = useState(false);

  const wordData = id ? mockWords[id] : null;

  if (!wordData) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <p className="font-mono">Palabra no encontrada</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">

      {/* Header */}
      <header className="border-b-2 border-gray-900 bg-white p-4 flex items-center justify-between">

        <button
          onClick={() => navigate(-1)}
          className="p-2 border-2 border-gray-900"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>

        <h1 className="text-xl font-mono">
          DETALLES DE PALABRA
        </h1>

        <button
          onClick={() => setIsFavorite(!isFavorite)}
          className={`p-2 border-2 border-gray-900 ${
            isFavorite ? "bg-gray-900" : "bg-white"
          }`}
        >
          <Heart
            className={`w-5 h-5 ${
              isFavorite ? "text-white fill-white" : ""
            }`}
          />
        </button>

      </header>

      {/* Word Content */}
      <main className="flex-1 p-4 overflow-y-auto">

        <div className="max-w-md mx-auto space-y-4">

          {/* Main Word Card */}
          <div className="border-4 border-gray-900 bg-white p-6">

            <div className="flex items-start justify-between mb-4">

              <div>

                <p className="text-xs font-mono text-gray-500 mb-2">
                  BRUNCA
                </p>

                <h2 className="text-4xl font-mono mb-4">
                  {wordData.word}
                </h2>

              </div>

              <button className="p-3 border-2 border-gray-900">
                <Volume2 className="w-5 h-5" />
              </button>

            </div>

            <div className="border-t-2 border-gray-900 pt-4">

              <p className="text-xs font-mono text-gray-500 mb-2">
                ESPAÑOL
              </p>

              <p className="text-2xl font-mono text-blue-600">
                → {wordData.spanish}
              </p>

            </div>

          </div>

          {/* Category */}
          <div className="border-2 border-gray-900 bg-white p-4">

            <p className="text-xs font-mono text-gray-500 mb-1">
              CATEGORÍA
            </p>

            <p className="font-mono">
              {wordData.category}
            </p>

          </div>

          {/* Description */}
          <div className="border-2 border-gray-900 bg-white p-4">

            <p className="text-xs font-mono text-gray-500 mb-2">
              DESCRIPCIÓN
            </p>

            <p className="font-mono">
              {wordData.description}
            </p>

          </div>

          {/* Examples */}
          <div className="border-2 border-gray-900 bg-white p-4">

            <p className="text-xs font-mono text-gray-500 mb-3">
              EJEMPLOS
            </p>

            <div className="space-y-2">

              {wordData.examples.map(
                (example: string, index: number) => (
                  <div
                    key={index}
                    className="p-3 bg-gray-100 border border-gray-300"
                  >

                    <p className="font-mono text-sm">
                      • {example}
                    </p>

                  </div>
                )
              )}

            </div>

          </div>

          {/* Wireframe Notes */}
          <div className="p-4 border-2 border-dashed border-gray-400">

            <p className="text-xs font-mono text-gray-500">
              [WIREFRAME] Pantalla de Detalles de Palabra
              <br />- Reproducción futura de pronunciación
              <br />- Ejemplos pendientes de validación comunitaria
              <br />- Compatibilidad con favoritos
            </p>

          </div>

        </div>

      </main>

    </div>
  );
}
