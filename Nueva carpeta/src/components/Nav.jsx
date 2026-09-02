import React from 'react';
import { Link } from 'react-router-dom';

function Nav() {
  return (
    <nav>
      <Link to="/">Inicio</Link> | 
      <Link to="/login">Iniciar Sesión</Link>
    </nav>
  );
}

export default Nav;