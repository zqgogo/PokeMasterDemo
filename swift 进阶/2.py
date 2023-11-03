# log_dir = '/Users/qilitech.ltd/Desktop/test/logs'
# log_file = '/Users/qilitech.ltd/Desktop/test/error.log'
# photo_dir = '/Users/qilitech.ltd/Desktop/test'
# data_file = '/Users/qilitech.ltd/Desktop/test/协会上传.xlsx'  
# results_dir = '/Users/qilitech.ltd/Desktop/test/results/'

import os
import pandas as pd
import shutil
import logging
import xlsxwriter

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

    # 循环处理每个分割数据
    for i, split_df in enumerate(split_dfs):
        print(f'开始处理第{i+1}组,共{len(split_df)}条数据')
        
        # 创建结果目录
        result_sub_dir = os.path.join(results_dir, f'result_{i+1}')
        try:
            os.makedirs(result_sub_dir)
        except Exception as e:
            logger.error(f'创建目录 {result_sub_dir} 失败:{e}')
        
        try:
             # 写入Excel数据
            excel_file = os.path.join(result_sub_dir, 'data.xlsx')
            # split_df.to_excel(excel_file, index=False)  
            fileWriter = pd.ExcelWriter(excel_file, engine='xlsxwriter')
            split_df.to_excel(fileWriter, index=False) 
            print(f'第{i+1}组Excel数据写入成功')

            workbook = fileWriter.book
            worksheet = fileWriter.sheets['Sheet1']
            print(f'第{i+1}组Excel数据开始添加图片超链接')

            # 插入图片
            # 读取Excel并插入图片    
            # df = pd.read_excel(excel_file, engine='openpyxl')

            # 设置图片列名 
            img_col = '营业执照照片'

            imgs = split_df[img_col]

            red_format = workbook.add_format({
                'font_color': 'blue',
                'bold':       1,
                'underline':  1,
                'font_size':  12,
            })

            worksheet.set_column("AE:AE", 30, cell_format=red_format)

            for j in range(len(imgs)):
                img = imgs[j]
                worksheet.write_url(j+1, 30, os.path.join(result_sub_dir, img), red_format, string=img)  # 写入本地超链接
                # worksheet.insert_image(j+2, 31, os.path.join(result_sub_dir, img))

            # fileWriter.save()
            split_df.to_excel(fileWriter, index=False) 
            fileWriter.close()
            print(f'第{i+1}组Excel数据添加图片超链接成功')
        except Exception as e:
            logger.error(f'写入数据或图片 {result_sub_dir} 失败:{e}')


        # 复制对应图片
        for j, row in split_df.iterrows():
            photo_name = f'{row["营业执照照片"]}'
            src = os.path.join(photo_dir, photo_name)
            dst = os.path.join(result_sub_dir, photo_name)
            try:
                shutil.copy(src, dst)
                print(f'已复制第{i+1}组第{j+1}条记录图片')
            except Exception as e:
                logger.error(f'复制图片 {src} 出错:{e}')
                
print('所有数据处理完成!')
