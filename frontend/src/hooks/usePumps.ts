import useSWR from 'swr'
import {fetcher} from './api'
import type {Pump} from '../pages/api/pumps'


export function usePumps(): { pumps: Pump[], isLoading: boolean, error?: Error } {
  const { data, error, isLoading } = useSWR('/api/pumps', fetcher)

  return { pumps: data ?? [], isLoading, error }
}
