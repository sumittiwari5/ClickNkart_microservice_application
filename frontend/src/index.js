import React from 'react';
import ReactDOM from 'react-dom/client';
// import './index.css';
import App from './App';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
// import reportWebVitals from './reportWebVitals';
import Home from './components/Home';
import Register from './components/Register';
import Login from './components/Login';
import ProductDetail from './components/ProductDetail';
import AddProduct from './components/AddProduct';
import UpdateProduct from './components/UpdateProduct';
import CartList from './components/CartList';
import Payment from './components/Payment';
import MyOrders from './components/MyOrders';
import OrderDetails from './components/OrderDetails';

const router = createBrowserRouter([
  {
    path:'/',
    element: <App />,
    children:[
      {
        path:'',
        element: <Home />
      },
      {
        path:'login',
        element: <Login />
      },
      {
        path:'register',
        element:<Register />
      },
      {
        path:'details/:id',
        element: <ProductDetail />
      },
      {
        path:'add-product',
        element: <AddProduct />
      },
      {
        //  link :  /update/${params.id}
        path: 'update/:id',
        element: <UpdateProduct />
      },
      {
        path:'mycart',
        element: <CartList />
      },
      {
        path:'payment',
        element: <Payment />
      },
      {
        path:'myorders',
        element: <MyOrders />
      },
      {
        path:'order-details',
        element: <OrderDetails />
      }
    ]
  }
])
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  // <React.StrictMode>
    <RouterProvider router={router} />
  // </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
// reportWebVitals();
