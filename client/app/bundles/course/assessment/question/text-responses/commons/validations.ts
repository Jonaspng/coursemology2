import {
  AttachmentType,
  SolutionData,
} from 'types/course/assessment/question/text-responses';
import {
  AnyObjectSchema,
  array,
  bool,
  number,
  object,
  string,
  ValidationError,
} from 'yup';

import { MessageTranslator } from 'lib/hooks/useTranslation';

import translations from '../../../translations';
import getIndexAndKeyPath from '../../commons/utils';
import { commonQuestionFieldsValidation } from '../../components/CommonQuestionFields';

export const questionSchema = (
  t: MessageTranslator,
  defaultMaxAttachmentSize: number,
  defaultMaxAttachments: number,
): AnyObjectSchema =>
  commonQuestionFieldsValidation.shape({
    attachmentType: string()
      .oneOf(
        Object.values(AttachmentType),
        translations.validAttachmentSettingValues,
      )
      .required(translations.attachmentSettingRequired),
    maxAttachments: number().when('attachmentType', {
      is: AttachmentType.MULTIPLE_ATTACHMENT,
      then: number()
        .required()
        .min(2, translations.mustSpecifyPositiveMaxAttachment)
        .max(
          defaultMaxAttachments,
          t(translations.mustBeLessThanMaxAttachments, {
            defaultMax: defaultMaxAttachments,
          }),
        )
        .typeError(translations.mustSpecifyMaxAttachment),
    }),
    maxAttachmentSize: number().when('attachmentType', {
      is: AttachmentType.NO_ATTACHMENT,
      then: number(),
      otherwise: number()
        .required()
        .min(1, translations.mustSpecifyPositiveMaxAttachmentSize)
        .max(
          defaultMaxAttachmentSize,
          t(translations.mustBeLessThanMaxAttachmentSize, {
            defaultMax: defaultMaxAttachmentSize,
          }),
        )
        .typeError(translations.mustSpecifyMaxAttachmentSize),
    }),
    isAttachmentRequired: bool(),
  });

const solutionSchema = object({
  solutionType: string().required(translations.mustSpecifySolutionType),
  solution: string().when('toBeDeleted', {
    is: true,
    then: string().notRequired(),
    otherwise: string().required(translations.mustSpecifySolution),
  }),
  grade: number().when('toBeDeleted', {
    is: true,
    then: number().notRequired(),
    otherwise: number()
      .typeError(translations.mustSpecifyGrade)
      .required(translations.mustSpecifyGrade),
  }),
  explanation: string().nullable(),
  toBeDeleted: bool(),
});

const solutionsSchema = array().of(solutionSchema);

export type SolutionErrors = Partial<Record<keyof SolutionData, string>>;

export interface SolutionsErrors {
  error?: string;
  errors?: Record<number, SolutionErrors>;
}

export const validateSolutions = async (
  solutions: SolutionData[],
): Promise<SolutionsErrors | undefined> => {
  try {
    await solutionsSchema.validate(solutions, {
      abortEarly: false,
    });

    return undefined;
  } catch (validationErrors) {
    if (!(validationErrors instanceof ValidationError)) throw validationErrors;

    return validationErrors.inner.reduce<SolutionsErrors>((errors, error) => {
      const { path, message } = error;
      if (path) {
        const [index, key] = getIndexAndKeyPath<keyof SolutionData>(path);

        if (!errors.errors) errors.errors = {};
        if (!errors.errors[index]) errors.errors[index] = {};

        errors.errors[index][key] = message;
      }

      return errors;
    }, {});
  }
};
