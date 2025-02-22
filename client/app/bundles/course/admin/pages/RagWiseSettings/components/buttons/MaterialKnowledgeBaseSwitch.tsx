import { FC, memo, useEffect, useState } from 'react';
import { defineMessages } from 'react-intl';
import { Switch } from '@mui/material';
import equal from 'fast-deep-equal';
import { Material } from 'types/course/admin/ragWise';

import { MATERIAL_WORKFLOW_STATE } from 'lib/constants/sharedConstants';
import { useAppDispatch } from 'lib/hooks/store';
import toast from 'lib/hooks/toast';
import useTranslation from 'lib/hooks/useTranslation';

import { chunkMaterial, removeChunks } from '../../operations';

interface Props {
  materials: Material[];
}

const translations = defineMessages({
  addSuccess: {
    id: 'course.admin.RagWiseSettings.KnowledgeBaseSwitch.addSuccess',
    defaultMessage: 'Material(s) has been added to knowledge base.',
  },
  addFailure: {
    id: 'course.admin.RagWiseSettings.KnowledgeBaseSwitch.addFailure',
    defaultMessage: 'Material(s) could not be added to knowledge base.',
  },
  removeSuccess: {
    id: 'course.admin.RagWiseSettings.KnowledgeBaseSwitch.removeSuccess',
    defaultMessage: 'Material(s) has been removed from knowledge base.',
  },
  removeFailure: {
    id: 'course.admin.RagWiseSettings.KnowledgeBaseSwitch.removeFailure',
    defaultMessage: 'Material(s) could not be removed from knowledge base.',
  },
});

const MaterialKnowledgeBaseSwitch: FC<Props> = (props) => {
  const { materials } = props;
  const materialIds = materials.map((material) => material.id);
  const hasNoMaterials = materials.length === 0;
  const { t } = useTranslation();
  const [isLoading, setIsLoading] = useState(false);
  const dispatch = useAppDispatch();
  const notChunkedMaterials = materials.filter(
    (material) => material.workflowState !== MATERIAL_WORKFLOW_STATE.chunked,
  );
  const chunkedMaterials = materials.filter(
    (material) => material.workflowState === MATERIAL_WORKFLOW_STATE.chunked,
  );
  const chunkingMaterials = materials.filter(
    (material) => material.workflowState === MATERIAL_WORKFLOW_STATE.chunking,
  );
  const notChunkedMaterialIds = notChunkedMaterials.map(
    (material) => material.id,
  );
  const chunkedMaterialIds = chunkedMaterials.map((material) => material.id);

  const onAdd = (): Promise<void> => {
    setIsLoading(true);
    return dispatch(
      chunkMaterial(
        notChunkedMaterialIds,
        () => {
          setIsLoading(false);
          toast.success(t(translations.addSuccess));
        },
        () => {
          setIsLoading(false);
          toast.error(t(translations.addFailure));
        },
      ),
    );
  };

  const onRemove = (): void => {
    // setIsLoading(true);
    // return dispatch(removeChunks(material.folderId, material.id))
    //   .then(() => {
    //     toast.success(
    //       t(translations.removeSuccess, {
    //         material: material.name,
    //       }),
    //     );
    //   })
    //   .catch((error) => {
    //     toast.error(
    //       t(translations.removeFailure, {
    //         material: material.name,
    //       }),
    //     );
    //     throw error;
    //   })
    //   .finally(() => {
    //     setIsLoading(false);
    //   });
  };

  // useEffect(() => {
  //   if (
  //     material.workflowState === MATERIAL_WORKFLOW_STATE.chunking &&
  //     !isLoading
  //   ) {
  //     onAdd();
  //   }
  // }, [isLoading]);

  return (
    <Switch
      checked={
        hasNoMaterials ? false : chunkedMaterials.length === materials.length
      }
      color="primary"
      disabled={
        (chunkingMaterials.length > 0 &&
          chunkingMaterials.length === notChunkedMaterials.length) ||
        isLoading ||
        hasNoMaterials
      }
      onChange={(_, isChecked): void => {
        if (isChecked) {
          onAdd();
        } else {
          onRemove();
        }
      }}
    />
  );
};

export default memo(MaterialKnowledgeBaseSwitch, (prevProps, nextProps) => {
  return equal(prevProps, nextProps);
});
