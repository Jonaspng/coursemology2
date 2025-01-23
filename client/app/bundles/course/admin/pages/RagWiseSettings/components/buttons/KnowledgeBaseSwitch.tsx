import { FC, memo, useEffect, useState } from 'react';
import { defineMessages } from 'react-intl';
import { Switch } from '@mui/material';
import equal from 'fast-deep-equal';
import { Material } from 'types/course/admin/ragWise';

import { useAppDispatch } from 'lib/hooks/store';
import toast from 'lib/hooks/toast';
import useTranslation from 'lib/hooks/useTranslation';

import { chunkMaterial, removeChunks } from '../../operations';

interface Props {
  material: Material;
}

const translations = defineMessages({
  addSuccess: {
    id: 'course.material.folders.WorkbinTableButtons.addFailure',
    defaultMessage: ' has been added to knowledge base',
  },
  addFailure: {
    id: 'course.material.folders.WorkbinTableButtons.addFailure',
    defaultMessage: ' could not be added to knowledge base',
  },
  removeSuccess: {
    id: 'course.material.folders.WorkbinTableButtons.removeSuccess',
    defaultMessage: ' has been removed from knowledge base',
  },
  removeFailure: {
    id: 'course.material.folders.WorkbinTableButtons.removeFailure',
    defaultMessage: ' could not be removed from knowledge base',
  },
});

const KnowledgeBaseSwitch: FC<Props> = (props) => {
  const { material } = props;
  const { t } = useTranslation();
  const [isLoading, setIsLoading] = useState(false);
  const dispatch = useAppDispatch();

  const onAdd = (): Promise<void> => {
    setIsLoading(true);
    return dispatch(
      chunkMaterial(
        material.folderId,
        material.id,
        () => {
          setIsLoading(false);
          toast.success(`"${material.name}" ${t(translations.addSuccess)}`);
        },
        () => {
          setIsLoading(false);
          toast.error(`"${material.name}" ${t(translations.addFailure)}`);
        },
      ),
    );
  };

  const onRemove = (): Promise<void> => {
    setIsLoading(true);
    return dispatch(removeChunks(material.folderId, material.id))
      .then(() => {
        toast.success(`"${material.name}" ${t(translations.removeSuccess)}`);
      })
      .catch((error) => {
        const errorMessage = error.response?.data?.errors
          ? error.response.data.errors
          : '';
        toast.error(
          `"${material.name}" ${t(translations.removeFailure)} - ${errorMessage}`,
        );
        throw error;
      })
      .finally(() => {
        setIsLoading(false);
      });
  };

  useEffect(() => {
    if (material.workflowState === 'chunking' && !isLoading) {
      onAdd();
    }
  }, [isLoading]);

  return (
    <Switch
      key={material.workflowState}
      checked={material.workflowState === 'chunked'}
      color="primary"
      disabled={isLoading || material.workflowState === 'chunking'}
      onChange={material.workflowState === 'not_chunked' ? onAdd : onRemove}
    />
  );
};

export default memo(KnowledgeBaseSwitch, (prevProps, nextProps) => {
  return equal(prevProps, nextProps);
});
