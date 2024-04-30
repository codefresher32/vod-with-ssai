import {
    createBrowserRouter,
  } from "react-router-dom";
import VideoPortal from "./VideoPortal";
import ContentCreator from "./ContentCreator";


const routes = createBrowserRouter([
    {
        path: "/",
        element: <VideoPortal/>
      },
    {
        path: "/content-creator",
        element: <ContentCreator/>,
    },{
        path: "/app",
        element: <VideoPortal/>,
    }
]);

export default routes;