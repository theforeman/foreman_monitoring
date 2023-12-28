import React, { createElement } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  Grid,
  GridItem,
} from '@patternfly/react-core';
import {
  CheckCircleIcon,
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
  QuestionCircleIcon,
} from '@patternfly/react-icons';
import { Table, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import PermissionDenied from 'foremanReact/components/PermissionDenied';
import Loading from 'foremanReact/components/Loading';
import SkeletonLoader from 'foremanReact/components/common/SkeletonLoader';
import DefaultLoaderEmptyState from 'foremanReact/components/HostDetails/DetailsCard/DefaultLoaderEmptyState';
import CardTemplate from 'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate';

const STATUS_ICONS = {
  'ok': CheckCircleIcon,
  'warning': ExclamationTriangleIcon,
  'critical': ExclamationCircleIcon,
};

const STATUS_STYLES = {
  'ok': 'ok',
  'warning': 'warn',
  'critical': 'critical',
};

const status_icon = (result_status) => {
  const cls = STATUS_ICONS[result_status] || QuestionCircleIcon;
  const style = STATUS_STYLES[result_status] || 'question';
  return createElement(cls, { className: `status-${style}` });
};

const MonitoringResults = ({ hostId }) => {
  const {
    response,
    status,
  } = useAPI('get', `/api/hosts/${hostId}/monitoring/results`, `get-monitoring-results-${hostId}`);

  switch (status) {
    case STATUS.PENDING: {
      return <Loading />
    }
    case STATUS.ERROR: {
      // In case of an error, response is an Error object
      if (response.response?.status === 403) {
        return <PermissionDenied missingPermissions={['view_monitoring_results']} />;
      } else {
        // TODO
      }
    }
    case STATUS.RESOLVED: {
      return (
        <Table variant="compact" aria-label={__("Monitoring Results")}>
          <Thead>
            <Tr>
              <Th>{__('Service')}</Th>
              <Th>{__('Status')}</Th>
            </Tr>
          </Thead>
          <Tbody>
            {response?.results?.map((result) => (
              <Tr key={`monitoring-result-${result.id}`}>
                <Td>{result.service}</Td>
                <Td>{status_icon(result.status)} {result.status_label}</Td>
              </Tr>
            ))}
          </Tbody>
        </Table>
      );
    }
    default: {
      return __('N/A');
    }
  }
};

MonitoringResults.propTypes = {
  hostId: PropTypes.number.isRequired,
};

const MonitoringTab = ({
  response: {
    id: hostId,
    monitoring_proxy_id: monitoringProxyId,
    monitoring_proxy_name: monitoringProxyName,
  },
  status,
}) => (
  <Grid hasGutter>
    <GridItem span={4}>
      <CardTemplate header={__('Monitoring details')}>
        <DescriptionList isCompact>
          <DescriptionListGroup>
            <DescriptionListTerm>{__('Monitoring Proxy')}</DescriptionListTerm>
            <DescriptionListDescription>
              <SkeletonLoader
                emptyState={<DefaultLoaderEmptyState />}
                status={status}
              >
                {monitoringProxyId && <a href={`/smart_proxies/${monitoringProxyId}`}>{monitoringProxyName}</a>}
              </SkeletonLoader>
            </DescriptionListDescription>
          </DescriptionListGroup>
        </DescriptionList>
      </CardTemplate>
    </GridItem>
    <GridItem span={8}>
      <SkeletonLoader
        emptyState={<DefaultLoaderEmptyState />}
        status={status}
      >
        {hostId && monitoringProxyId && <MonitoringResults hostId={hostId} />}
      </SkeletonLoader>
    </GridItem>
  </Grid>
);

MonitoringTab.propTypes = {
  response: PropTypes.object,
  status: PropTypes.string,
};
MonitoringTab.defaultProps = {
  response: {},
  status: STATUS.PENDING,
};

export default MonitoringTab;
