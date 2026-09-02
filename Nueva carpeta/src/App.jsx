import React from 'react';
import { createBrowserRouter, RouterProvider, Outlet } from 'react-router-dom';
import Header from './components/Header';
import Nav from './components/Nav';
import Main from './components/Main';
import Gallery from './components/Gallery';
import Footer from './components/Footer';
import InicioSesion from './components/InicioSesion';

function Layout() {
  return (
    <div>
      <Header />
      <Nav />
      <Outlet /> 
      <Gallery />
      <Footer />
    </div>
  );

}


// Configuración de rutas
const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        path: '/',
        element: <Main />,
      },
      {
        path: '/login',
        element: <InicioSesion />,
      },
    ],
  },
]);


function App() {
  return <RouterProvider router={router} />;
}

export default App;