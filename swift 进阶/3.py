# log_dir = '/Users/qilitech.ltd/Desktop/test/logs'
# log_file = '/Users/qilitech.ltd/Desktop/test/error.log'
# photo_dir = '/Users/qilitech.ltd/Desktop/test'
# data_file = '/Users/qilitech.ltd/Desktop/test/协会上传.xlsx'  
# results_dir = '/Users/qilitech.ltd/Desktop/test/results/'

import os
import pandas as pd
import shutil
import logging

def setup_logger(name, log_file, level=logging.INFO):
    formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s')
    handler = logging.FileHandler(os.path.abspath(log_file))
    handler.setFormatter(formatter) 
    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.addHandler(handler)
    return logger

log_dir = '/Users/qilitech.ltd/Desktop/test/logs'
log_file = '/Users/qilitech.ltd/Desktop/test/logs/error.log'
photo_dir = '/Users/qilitech.ltd/Desktop/test'
data_file = '/Users/qilitech.ltd/Desktop/test/协会上传.xlsx'  
results_dir = '/Users/qilitech.ltd/Desktop/test/results/'

try:
    if not os.path.exists(log_dir):
        os.makedirs(log_dir) 
except OSError as e:
    print(f"创建日志目录失败:{e}")

logger = setup_logger('error_logger', 'error.log')

try:
    df = pd.read_excel(data_file)
except Exception as e:
    logger.error(f'读取Excel出错:{e}') 

print(f'开始处理Excel数据,总记录数:{len(df)}')

if df is not None:

    # 分割数据,每10条记录一组
    split_dfs = [df[i:i+10] for i in range(0,len(df),10)] 
    print(f'共分割出{len(split_dfs)}组数据')

    # 处理每组数据
    for i, split_df in enumerate(split_dfs):
      
        print(f'开始处理第{i+1}组数据,记录数:{len(split_df)}')  

        # 创建结果子目录
        result_dir = os.path.join(results_dir, f'result_{i+1}')
        try:
            os.makedirs(result_dir)
        except Exception as e:
            logger.error(f'创建目录 {result_dir} 出错:{e}')

        # 写入分组后Excel数据
        excel_file = os.path.join(result_dir, 'data.xlsx')
        try:
            split_df.to_excel(excel_file, index=False)  
            print(f'已将第{i+1}组数据写入Excel')
        except Exception as e:
            logger.error(f'写入Excel {excel_file} 出错:{e}')

        # 复制对应图片
        for j, row in split_df.iterrows():
            photo_name = f'{row["营业执照照片"]}'
            src = os.path.join(photo_dir, photo_name)
            dst = os.path.join(result_dir, photo_name)
            try:
                shutil.copy(src, dst)
                print(f'已复制第{i+1}组第{j+1}条记录图片')
            except Exception as e:
                logger.error(f'复制图片 {src} 出错:{e}')
                
print('所有数据处理完成!')

