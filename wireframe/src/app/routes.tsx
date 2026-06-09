import { createBrowserRouter } from "react-router";
import { Home } from "./components/Home";
import { SearchResults } from "./components/SearchResults";
import { WordDetail } from "./components/WordDetail";
import { Favorites } from "./components/Favorites";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Home,
  },
  {
    path: "/search",
    Component: SearchResults,
  },
  {
    path: "/word/:id",
    Component: WordDetail,
  },
  {
    path: "/favorites",
    Component: Favorites,
  },
]);
