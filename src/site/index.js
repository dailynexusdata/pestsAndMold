/**
 * @author alex
 * @since 2021-09-25
 */
import './styles.scss';

import { csv, json } from 'd3-fetch';

// import plot functions here:
// import makePLOT_NAME from "./PLOT_NAME";
import moldMap from '../plots/moldmap';

(async () => {
  // import data - use csv or json:
  // const data = await csv('file path or url');
  const locations = await json('dist/data/locations.json');
  const moldCounts = await csv('dist/data/mold_count.csv', (d) => ({
    ...d,
    n: +d.n,
  }));

  const resize = () => {
    // call imported plots here:
    // makePLOT_NAME(data);
    moldMap(moldCounts, locations);
  };

  window.addEventListener('resize', () => {
    resize();
  });

  resize();
})();
