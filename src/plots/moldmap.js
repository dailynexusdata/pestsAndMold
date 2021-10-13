import { max } from 'd3-array';
import { nest } from 'd3-collection';
import { scaleLinear } from 'd3-scale';
import { select, pointer } from 'd3-selection';
import { latLng } from 'leaflet';
import GetMap from './getMap';

const getLatLng = (map, { lat, lng }) => {
  // eslint-disable-next-line new-cap
  const ll = new latLng(lat, lng);
  return map.latLngToLayerPoint(ll);
};

const main = (data, locs) => {
  const container = select('#pest-and-mold-loc-map-container');

  container.selectAll('*').remove();

  container
    .append('h1')
    .text('Mold Reports in UCSB Housing')
    .attr('class', 'pest-and-mold')
    .style('margin', '0 0 5px 0');

  const hoverArea = container.append('div').style('position', 'relative');

  const tooltip = hoverArea
    .append('div')
    .style('display', 'none')
    .attr('class', 'pest-and-mold')
    .style('pointer-events', 'none')
    .style('position', 'absolute')
    .style('background-color', 'white')
    .style('padding', '10px')
    .style('border-radius', '10px')
    .style('border', '1px solid #d3d3d3');

  hoverArea.append('div').attr('id', 'pest-and-mold-loc-map');

  container
    .append('a')
    .attr('class', 'pest-and-mold')
    .attr(
      'href',
      'https://www.police.ucsb.edu/sites/default/files/UCSB%20Crime%20Log.pdf',
    )
    .text('Source: UCSB Housing, Dining & Auxiliary Enterprises');

  const [map, svg] = new GetMap('pest-and-mold-loc-map', false);

  const combined = data.map((d) => ({
    ...d,
    ll: locs.find((l) => l.name === d.building),
  }));

  const r = scaleLinear()
    .domain([0, max(combined, (d) => d.n)])
    .range([1, 13]);

  const pt = getLatLng(map, {
    lat: 34.403243170284576,
    lng: -119.88137054417167,
  });

  const svgG = svg.append('g').attr('transform', `translate(${pt.x}, ${pt.y})`);

  const update = () => {
    const circs = svg.selectAll('.mold-locs').data(combined);

    circs
      .enter()
      .append('circle')
      .attr('class', 'mold-locs')
      .attr('fill', '#E15759')
      .attr('fill-opacity', 0.9)
      .attr('r', (d) => r(d.n))
      .attr('cx', (d) => getLatLng(map, d.ll).x)
      .attr('cy', (d) => getLatLng(map, d.ll).y);

    circs
      .attr('cx', (d) => getLatLng(map, d.ll).x)
      .attr('cy', (d) => getLatLng(map, d.ll).y);

    const width = 200;
    const totalWidth = Math.min(window.innerWidth - 40, 600);

    circs.on('mousemove touchstart', (event, d) => {
      const [mouseX, mouseY] = pointer(event);

      tooltip
        .style('display', 'block')
        .style('z-index', 100000)
        .style('width', `${width}px`)
        .style('left', `${Math.min(mouseX, totalWidth - width)}px`)
        .style('top', `${mouseY}px`)
        .html(`${d.building}<hr />Mold reports since 2016: ${d.n}`);
    });

    circs.on('mouseout touchcancel', () => {
      tooltip.style('display', 'none');
    });

    const pt = getLatLng(map, {
      lat: 34.403243170284576,
      lng: -119.88137054417167,
    });

    svgG.attr('transform', `translate(${pt.x}, ${pt.y})`);

    const legend = svgG
      .selectAll('.leg')
      .data([1, 10, 28])
      .enter()
      .append('g')
      .attr('class', 'leg');

    legend
      .append('circle')
      .attr('r', (d) => r(d))
      .attr('cx', (d, i) => i * 20 + 5 + r(d) * 3)
      .attr('fill', '#E15759')
      .attr('fill-opacity', 0.9)
      .attr('cy', 25);

    legend
      .append('text')
      .text((d, i) => d + (i === 2 ? ' reports of mold' : ''))
      .attr('x', (d, i) => i * 20 + r(d) * 3)
      .attr('y', 55)
      .attr('fill', '#E15759')
      .attr('text-anchor', 'start')
      .attr('font-size', '13pt');

    legend
      .append('text')
      .text('Reports of mold since 2016')
      .attr('x', 0)
      .attr('y', 0)
      .attr('fill', '#E15759')
      .attr('font-size', '15pt');
  };

  map.on('moveend', () => {
    update();
  });

  // map.on('click', (d) => {
  //   console.log(d);
  // });

  update();
};
export default main;
