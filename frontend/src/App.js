import { Outlet } from 'react-router-dom';
import Navbar from './components/Navbar';
import logo from './logo.svg';
// import './App.css';

function App() {
  return (
    <div className='container-fluid'>
      <Navbar />
      <Outlet />
    </div>
  );
}

export default App;
