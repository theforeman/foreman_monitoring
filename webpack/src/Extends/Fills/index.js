import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import MonitoringTab from '../Host/MonitoringTab';

const fills = [
  {
    slot: 'host-details-page-tabs',
    name: 'Monitoring',
    component: props => <MonitoringTab {...props} />,
    weight: 500,
    metadata: { title: __('Monitoring') },
  },
];

export const registerFills = () => {
  fills.forEach(({ slot, name, component: Component, weight, metadata }) =>
    addGlobalFill(
      slot,
      name,
      <Component key={`monitoring-fill-${name}`} />,
      weight,
      metadata
    )
  );
};
