import React, { useEffect, useCallback } from 'react';
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
import { Table, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { get } from 'foremanReact/redux/API';
import { selectAPIStatus, selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import Loading from 'foremanReact/components/Loading';
import SkeletonLoader from 'foremanReact/components/common/SkeletonLoader';
import DefaultLoaderEmptyState from 'foremanReact/components/HostDetails/DetailsCard/DefaultLoaderEmptyState';
import CardTemplate from 'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate';

const STATUS_ICONS = {
  'ok': 'pficon-ok status-ok',
  'warning': 'pficon-info status-warn',
  'critical': 'pficon-error-circle-o status-error',
}

const status_icon_class = (result_status) => {
  return STATUS_ICONS[result_status] || 'pficon-help status-question';
};

const MonitoringResults = ({ hostId }) => {
  const dispatch = useDispatch();
  const API_KEY = `get-monitoring-results-{hostId}`;
  const status = useSelector(state => selectAPIStatus(state, API_KEY));
  const { results, itemCount, response } = useSelector(state =>
    selectAPIResponse(state, API_KEY)
  );

  const fetchResults = useCallback(
    () => {
      if (!hostId) return;
      dispatch(
        get({
          key: API_KEY,
          url: `/api/hosts/${hostId}/monitoring/results`,
          params: {
            per_page: 'all',
          },
        })
      );
    },
    [API_KEY, dispatch, hostId],
  );

  useEffect(() => {
    fetchResults();
  }, [fetchResults]);

  if (response?.status === 403) {
    return <PermissionDenied missingPermissions={['view_monitoring_results']} />;
  }

  return (
    <Table variant="compact" aria-label={__("Monitoring Results")}>
      <Thead>
        <Tr>
          <Th>{__('Service')}</Th>
          <Th>{__('Status')}</Th>
        </Tr>
      </Thead>
      <Tbody>
        <SkeletonLoader
          customSkeleton={<Tr><Td colSpan={2}><Loading /></Td></Tr>}
          status={status || STATUS.PENDING}
        >
          {results && results.map((result) => (
            <Tr key={`monitoring-result-${result.id}`}>
              <Td>{result.service}</Td>
              <Td><span className={status_icon_class(result.status)}></span> {result.status_label}</Td>
            </Tr>
          ))}
        </SkeletonLoader>
      </Tbody>
    </Table>
  );
};

MonitoringResults.propTypes = {
  hostId: PropTypes.number.isrequired,
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
                {monitoringProxyId && (<a href={`/smart_proxies/${monitoringProxyId}`}>{monitoringProxyName}</a>)}
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
        {monitoringProxyId && hostId && (<MonitoringResults hostId={hostId} />)}
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
