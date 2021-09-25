/**
 * @author alex
 * @since 2021-09-25
 */
import './styles.scss';

import { csv, json } from 'd3-fetch';

// import plot functions here:
// import makePLOT_NAME from "./PLOT_NAME";

(async () => {
  // import data - use csv or json:
  // const data = await csv('file path or url');

  const resize = () => {
    // call imported plots here:
    // makePLOT_NAME(data);
  };

  window.addEventListener('resize', () => {
    resize();
  });

  resize();
})();
