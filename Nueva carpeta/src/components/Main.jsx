import React, { useState, useEffect } from 'react';
import { Link } from "react-router-dom";

function Main() {

  //Cambio de pagina
  
  return (
    <main>
      <h1>Página Principal</h1>
      <Link to="/login">Ir a Iniciar Sesión</Link>
    </main>
  );








///////////////////////////////////////////////////////

  // Rutas relativas a la carpeta public/
  const imagenes = [
    '/lupa.avif',
    '/peladin.webp'
  ];

  const [contador, setContador] = useState(0);

  // Cambio automático de imágenes cada 5 segundos
  useEffect(() => {
    if (!imagenes || imagenes.length === 0) return;
    const intervalo = setInterval(() => {
      setContador((prev) => (prev + 1) % imagenes.length);
    }, 5000);

    return () => clearInterval(intervalo);
  }, [imagenes.length]);

  return (
    <>
      {/* 1. Barra superior con movimiento (Ticker) */}
      <div className="top-bar bg-dark text-white py-2 overflow-hidden">
        <div className="ticker-banner">
          <div className="ticker-track">
            <span>TODO PARA TU AUTO PROMOS IMBATIBLES &nbsp;&bull;&nbsp; </span>
            <span>CONSEGUIRAS TODOS LOS REPUESTOS AQUI &nbsp;&bull;&nbsp; </span>
            <span>OFERTAS QUE SALVARAN A TU TRANSPORTE &nbsp;&bull;&nbsp; </span>
          </div>

          <div className="ticker-track" aria-hidden="true">
            <span>TODO PARA TU AUTO PROMOS IMBATIBLES &nbsp;&bull;&nbsp; </span>
            <span>CONSEGUIRAS TODOS LOS REPUESTOS AQUI &nbsp;&bull;&nbsp; </span>
            <span>OFERTAS QUE SALVARAN A TU TRANSPORTE &nbsp;&bull;&nbsp; </span>
          </div>
        </div>
      </div>

      {/* 2. Navbar de Bootstrap */}
      <nav className="navbar navbar-expand-lg navbar-light bg-light shadow-sm">
        <div className="container-fluid">
          <button
            className="navbar-toggler"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#navbarNavAltMarkup"
            aria-controls="navbarNavAltMarkup"
            aria-expanded="false"
            aria-label="Toggle navigation"
          >
            <span className="navbar-toggler-icon"></span>
          </button>

          <div className="collapse navbar-collapse" id="navbarNavAltMarkup">
            <div className="navbar-nav me-auto">
              <a className="nav-link active" href="/Index.html">
                Home <span className="visually-hidden">(current)</span>
              </a>
              <a className="nav-link" href="/Inicio de Sesion.html">
                Inicio de Sesion
              </a>
              <a className="nav-link" href="/Crear cuenta.html">
                Crear cuenta
              </a>
            </div>

            <form className="d-flex" role="search">
              <input
                className="form-control me-2"
                type="search"
                placeholder="Buscar"
                aria-label="Search"
              />
              <button className="btn btn-outline-success" type="submit">
                Buscar
              </button>
            </form>
          </div>
        </div>
      </nav>

      {/* 3. Carrusel a pantalla completa (Borde a borde, sin botones) */}
      <div
        id="slider"
        className="position-relative w-100 overflow-hidden bg-dark"
        style={{ height: '450px' }} // Puedes ajustar el alto del carrusel aquí
      >
        {imagenes.map((img, index) => (
          <img
            key={index}
            src={img}
            alt={`Slide ${index}`}
            className="position-absolute top-0 start-0 w-100 h-100 object-fit-cover"
            style={{
              opacity: index === contador ? 1 : 0,
              transition: 'opacity 1s ease-in-out'
            }}
          />
        ))}
      </div>
    </>
  );
}

export default Main;